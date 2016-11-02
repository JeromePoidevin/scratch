scratch
=======

my 1st repo

=======

git remote add -m master scratch git@github.com:JeromePoidevin/scratch.git
git branch --set-upstream scratch scratch/master

git add
git commit -a
git reset

git clone https://github.com/JeromePoidevin/scratch.git
git clone ssh://git@github.com/JeromePoidevin/scratch.git
git diff
git push
git push [remote-name] [branch-name]
git pull

git config --list
git config --global  -> ~/.gitconfig
git config -> .git/config

git log
git log -p
git log --pretty=oneline
git log origin/master..HEAD  # show local commits (not pushed)
git log origin/master..      # show local commits (not pushed)
git log @{push}..            # Starting with Git 2.5+ (Q2 2015)

git remote -v
git remote set-url <remote name> <remote url>
  	url = git@github.com:JeromePoidevin/scratch.git
  	url = ssh://git@github.com/JeromePoidevin/scratch.git
  	url = https://JeromePoidevin@github.com/JeromePoidevin/scratch.git

https://help.github.com/articles/https-cloning-errors
https://help.github.com/articles/which-remote-url-should-i-use/
http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes
http://rogerdudler.github.io/git-guide/index.fr.html
http://stackoverflow.com/questions/7438313/pushing-to-git-returning-error-code-403-fatal-http-request-failed
http://stackoverflow.com/questions/3777075/ssl-certificate-rejected-trying-to-access-github-over-https-behind-firewall

