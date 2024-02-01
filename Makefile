publish:
	@echo "I know it is too simple, but I am too lazy to write a script for it."
	git status
	git add -A .
	git commit -m 'yo Im adding some new stuff'
	git push origin main
