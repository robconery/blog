run:
	bundle exec jekyll serve --livereload --drafts --future --port 5555 --livereload_port 35729

drop_import:
	rm ./_site/ghost_export.json && rm ./_site/ghost-import.json

build:
	bundle exec jekyll build

import: drop_import build
	migrate json html ./_site/ghost_export.json

