module PaginationHelper
  def custom_paginate(collection, per_page: 10)
    # Get current page from params or default to 1
    current_page = params[:page].to_i.positive? ? params[:page].to_i : 1

    # Calculate total pages
    total_pages = (collection.count.to_f / per_page).ceil
    total_pages = 1 if total_pages.zero?
    current_page = [[current_page, 1].max, total_pages].min

    # Paginate collection
    paginated_collection = collection.offset((current_page - 1) * per_page).limit(per_page)

    # Return paginated collection and page data
    {
      collection: paginated_collection,
      current_page: current_page,
      total_pages: total_pages
    }
  end

  def pagination_links(current_page, total_pages, page_param: :page, extra_params: nil)
    total_pages = total_pages.to_i
    return "".html_safe if total_pages <= 1

    current_page = current_page.to_i
    current_page = [[current_page, 1].max, total_pages].min

    links = []
    links << previous_page_link(current_page, page_param, extra_params) if current_page > 1
    links << page_number_links(current_page, total_pages, page_param, extra_params)
    links << next_page_link(current_page, total_pages, page_param, extra_params) if current_page < total_pages

    content_tag :nav, class: "pagination" do
      safe_join(links)
    end
  end

  private

  # Link to the previous page
  def previous_page_link(current_page, page_param, extra_params)
    link_to("« Previous", pagination_params_for(current_page - 1, page_param, extra_params), class: "page-link")
  end

  # Link to the next page
  def next_page_link(current_page, total_pages, page_param, extra_params)
    link_to("Next »", pagination_params_for(current_page + 1, page_param, extra_params), class: "page-link")
  end

  # Display surrounding page numbers
  def page_number_links(current_page, total_pages, page_param, extra_params)
    window_size = 7
    half_window = window_size / 2

    # Set the start and end range
    start_page = [current_page - half_window, 1].max
    end_page = [start_page + window_size - 1, total_pages].min

    # Adjust start if we're near the end
    start_page = [end_page - window_size + 1, 1].max

    # Generate page links
    (start_page..end_page).map do |page|
      if page == current_page
        content_tag(:span, page, class: "page-link active", aria: { current: "page" })
      else
        link_to(page, pagination_params_for(page, page_param, extra_params), class: "page-link")
      end
    end.join.html_safe
  end

  def pagination_params_for(target_page, page_param, extra_params)
    base_params = extra_params || request.query_parameters
    base_params.to_h.deep_dup.merge(page_param.to_s => target_page)
  end
end
