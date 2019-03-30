{% include head.html %}
    <body id="page-top" class="index">
        <div class="col-sm-4">
            <div class="person">
                <img src="/img/people/{{ page.pic }}" class="img-responsive img-circle" alt="">
                <h4>{{ page.name }}</h4>
                <p class="text-primary">{{ page.position }}</p>
                <ul class="list-inline social-buttons">
                    <li>
                        <a href="{{ page.url }}">
                            <i class="fa fa-user"></i>
                        </a>
                    </li>
                    {% for network in page.social %}
                    <li>
                        <a href="{{ network.url }}">
                            <i class="fa fa-{{ network.title }}"></i>
                        </a>
                    </li>
                    {% endfor %}
                </ul>
            </div>
        </div>

    </body>
</html>
