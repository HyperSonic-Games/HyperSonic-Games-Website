dotnet publish -c:Release -p:GHPages=true
git subtree push --prefix bin\Release\net9.0\publish\wwwroot origin gh-pages