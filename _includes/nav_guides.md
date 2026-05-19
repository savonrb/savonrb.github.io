<div class="sidebar_version">
  {% if page.savon_version %}Savon {{ page.savon_version }}{% endif %}
</div>
<ul class="sidebar_nav">
  {% assign filtered_pages = site.pages | where: 'savon_version', page.nav_savon_version | sort: "order" %}
  {% for thispage in filtered_pages %}
    {% if page.url == thispage.url %}
      <li class="active"><a href="{{ thispage.url }}">{{ thispage.title }}</a></li>
    {% else %}
      <li><a href="{{ thispage.url }}">{{ thispage.title }}</a></li>
    {% endif %}
  {% endfor %}
</ul>
