$ErrorActionPreference = "Stop"

# Set your GitHub repo name
$repoName = "your-repo-name"
$publishDir = "dist"
$deployBranch = "gh-pages"

Write-Host "🔧 Publishing Blazor WebAssembly app..."
dotnet publish -c Release -o $publishDir

$wwwroot = Join-Path $publishDir "wwwroot"
$indexFile = Join-Path $wwwroot "index.html"
$notFoundFile = Join-Path $wwwroot "404.html"

Write-Host "📄 Copying index.html to 404.html..."
Copy-Item $indexFile $notFoundFile -Force

Write-Host "🛠 Updating <base href>..."
(Get-Content $indexFile) -replace '<base href="/" />', "<base href='/$repoName/' />" | Set-Content $indexFile

Write-Host "🌿 Setting up deployment branch '$deployBranch'..."
git worktree remove $deployBranch -f | Out-Null
git worktree add $deployBranch

Remove-Item "$deployBranch\*" -Recurse -Force
Copy-Item "$wwwroot\*" $deployBranch -Recurse

Push-Location $deployBranch
git add .
git commit -m "Deploy Blazor WebAssembly to GitHub Pages" -a
git push origin $deployBranch
Pop-Location

git worktree remove $deployBranch

Write-Host "✅ Deployment complete!"
Write-Host "Visit: https://$(git config --get remote.origin.url -replace '.*github.com[:/](.*)\.git','$1' | ForEach-Object { "https://$_".Replace(".git", '') }))/$repoName/"
