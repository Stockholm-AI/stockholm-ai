# Stockholm.AI webpage
The Stockholm.AI webpage.

# Deploy
* Install docker
* `sudo ./start.sh`

# Debug
```
{{ variable | inspect }}
```

# Debug view
```bash
JEKYLL_ENV=debug jekyll serve
```

# Images
## Resize
```bash
convert first-last.jpg -resize 220x220 first-last.jpg
```
## Check size
```bash
ls img/category | xargs file
```

# Logo
https://fedoraproject.org/wiki/Montserrat_Fonts
## Install the used font (Fedora)
```bash
sudo dnf install julietaula-montserrat-fonts
```
## Font style
Bold with letter spacing of `font_size/12`.

# Changes to `_config.yml`
`NOTE: not applicable for start.sh, only jekyll serve`
Changes to `_config.yml` does not propagate automatically with `jekyll serve`, instead put changing data under `_data` and keep the truly static stuff in `_config.yml`.
This also has the side-effect that if the `_config.yml` is missing when you start the `jekyll build --watch` it will just act like it's laking any data  and kindly compile everything with missing data (hence the `[[ -f _config ]]` check in the start script.

# More Help with Jekyll
For more details, read [documentation](http://jekyllrb.com/)

# Licensing
This code derives from [y7kim/agency-jekyll-theme](https://github.com/y7kim/agency-jekyll-theme) and is still distributed via Apache License Version 2.0 (See [LICENSE](https://github.com/Stockholm-AI/stockholm-ai/blob/master/LICENSE) for further information).

## Changes from derived software
To view the changes made from the derived content:
```
git diff a6ddd100833e7e9f8aa786fec110d97260b76b55 master 
```
