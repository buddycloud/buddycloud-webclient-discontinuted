post-deploy:
  
  
deploy:
	capt build
	cp build/undefined/* .
	cp public/stylesheets/.application.css /bundled-stylesheet.css
	# git commit -a -m "Production deployment"
	git push prod    