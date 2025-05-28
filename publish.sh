#!/bin/bash

set -e

REPO_NAME="your-repo-name"      # change this to your GitHub repo name
PUBLISH_DIR="dist"
DEPLOY_BRANCH="gh-pages"

echo "Building Blazor WebAssembly app..."
dotnet publish -c Release -o $PUBLISH_DIR

echo "Copying index.html to 404.html..."
cp $PUBLISH_DIR/wwwroot/index.html $PUBLISH_DIR/wwwroot/404.html

echo "Fixing <base href> in index.html..."
sed -i "s|<base href=\"/\" />|<base href=\"/${REPO_NAME}/\" />|" $PUBLISH_DIR/wwwroot/index.html

echo "Preparing deployment branch..."
git worktree remove $DEPLOY_BRANCH --force || true
git worktree add $DEPLOY_BRANCH

rm -rf $DEPLOY_BRANCH/*
cp -r $PUBLISH_DIR/wwwroot/* $DEPLOY_BRANCH/

cd $DEPLOY_BRANCH
git add .
git commit -m "Deploy Blazor WebAssembly to GitHub Pages" || echo "Nothing to commit"
git push origin $DEPLOY_BRANCH

cd ..
git worktree remove $DEPLOY_BRANCH

echo "✅ Deployment complete. Visit:"
echo "https://$(git config --get remote.origin.url | sed 's|.*github.com[:/]\(.*\)\.git|\1|' | sed "s|^|https://github.io/|")/${REPO_NAME}/"
