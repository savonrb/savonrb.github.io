<div>
  <strong>{% if page.savon_version %}Savon {{ page.savon_version }}{% endif %}&nbsp;</strong>
</div>
<ul>
  {% assign filtered_pages = site.pages | where: 'savon_version', page.nav_savon_version | sort: "order" %}
  {% for page in filtered_pages %}
    <li><a href="{{ page.url }}">{{ page.title }}</a></li>
  {% endfor %}
</ul>
