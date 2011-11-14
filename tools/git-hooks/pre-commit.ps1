## make sure everything is staged
#$nonCommitedFiles = git diff --name-only
#if ($nonCommitedFiles -ne $null) {
#    Write-Host "The following files are changed but not staged:"
#    Write-Host $nonCommitedFiles
#    Write-Host "Commit will be cancelled"
#    exit 3
#}

# build all the solutions under src
$msbuild = Get-Command MSBuild.exe -CommandType Application -ErrorAction SilentlyContinue

if (-not $msbuild) {
    Write-Host "Please run in a Visual Studio environment"
    Write-Host "(see http://bradwilson.typepad.com/blog/2010/03/vsvars2010ps1.html"
    Write-Host "or http://stackoverflow.com/questions/2124753/)"
    Write-Host "Commit will be cancelled"
    exit 1
}

$workingDirectory = git rev-parse --show-toplevel
if (-not $?) {
    Write-Host "Not inside a git repository, quitting"
    exit 4
}

# build all solutions
Get-ChildItem $workingDirectory\4.Dev\src\ -Recurse -Include *.sln | ForEach-Object {
    $solution = $_
    Write-Host "Building $solution"
    MSBuild.exe $solution /p:StyleCopTreatErrorsAsWarnings=false
    if (-not $?) {
        Write-Host "$solution did not build correctly"
        Write-Host "Commit will be cancelled"
        exit 2
    }
}

# analyze all assemblies, run unit tests
Get-ChildItem $workingDirectory\4.Dev\src\ -Recurse -Include *.csproj | ForEach-Object {
    $project = $_
    Write-Host "Verifying $project"
    MsBuild.exe $project /target:VerifyCommit
    if (-not $?) {
        Write-Host "$project did not pass commit verification"
        Write-Host "Commit will be cancelled"
        exit 3
    }
}

# exit with non-zero status code to stop the commit
