<ul>
  {% for version in site.versions %}
    <li>
      <a href="/{{ version.name }}">{{ version.title }}</a>
    </li>
  {% endfor %}
</ul>
