$git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue

if (-not $git) {
    Write-Host "Please install:";
    Write-Host "`tgit from http://git-scm.com/download";
    Write-Host "`tgit-tfs from https://github.com/spraints/git-tfs";
    Write-Host "Optional:";
    Write-Host "`tposh-git from https://github.com/dahlbyk/posh-git";
    exit;
}

$isInside = git rev-parse --is-inside-work-tree 2>$null;
if (-not $isInside) {
    Write-Host "Please run inside a git working tree";
    exit;
}

$gitDir = git rev-parse --git-dir;
$topDir = git rev-parse --show-toplevel;
$gitHooksDir = "$gitDir\hooks";
$toolsDir = "$topDir\4.dev\tools";

# remove .git\hooks if it exists
if (Test-Path $gitHooksDir) {
    if ((& $toolsDir\sysinternals\junction.exe $gitHooksDir) -match "No .* found") {
        Remove-Item $gitHooksDir -Recurse;
    } else {
        & $toolsDir\sysinternals\junction.exe -d $gitHooksDir;
    }
}

# link .git\hooks to tools\git-hooks in working tree
& $toolsDir\sysinternals\junction.exe $gitHooksDir "$toolsDir\git-hooks"

Write-Host "Done!"