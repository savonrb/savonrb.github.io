module LayoutHelper

  def page_title
    current_page.data.title
  end

  def page_name
    page_classes.split(' ').first
  end

  def page_version
    current_page.data.version
  end

  def page_order
    current_page.data.order
  end

  def show_sibling_navigation?
    !!page_order
  end

  def prev_page
    find_sibling(page_order - 1)
  end

  def next_page
    find_sibling(page_order + 1)
  end

  def link_to_page(page)
    link_to(page.data.title, page.url) if page
  end

  def find_sibling(order)
    current_page.siblings.find { |page| page.data.order == order }
  end

end
