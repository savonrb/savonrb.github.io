<div class="sidebar_version">
  {% if page.savon_version %}Savon {{ page.savon_version }}{% endif %}
</div>
<ul class="sidebar_nav">
  {% assign filtered_pages = site.pages | where: 'savon_version', page.nav_savon_version | sort: "order" %}
  {% for thispage in filtered_pages %}
    {% assign nav_title = thispage.nav_title | default: thispage.title %}
    {% if page.url == thispage.url %}
      <li class="active"><a href="{{ thispage.url }}">{{ nav_title }}</a></li>
    {% else %}
      <li><a href="{{ thispage.url }}">{{ nav_title }}</a></li>
    {% endif %}
  {% endfor %}
</ul>
