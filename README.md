# Stockholm.AI webpage

The Stockholm.AI webpage.

# Changes to `_config.yml`
Changes to `_config.yml` does not propagate automatically, instead put changing data under `_data` and keep the truly static stuff in `_config.yml`.
This also has the side-effect that if the `_config.yml` is missing when you start the `jekyll build --watch` it will just act like it's laking any data  and kindly compile everything with missing data (hence the `[[ -f _config ]]` check in the start script.

# Debug View
```bash
JEKYLL_ENV=debug jekyll serve
```

# More Help

For more details, read [documentation](http://jekyllrb.com/)

# Licensing
This code derives from [y7kim/agency-jekyll-theme](https://github.com/y7kim/agency-jekyll-theme) and is still distributed via Apache License Version 2.0 (See [LICENSE](https://github.com/Stockholm-AI/stockholm-ai/blob/master/LICENSE) for further information).

## Changes from derived software
To view the changes made from the derived content:
```
git diff a6ddd100833e7e9f8aa786fec110d97260b76b55 master 
```
