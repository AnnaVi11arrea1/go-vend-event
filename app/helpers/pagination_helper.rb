module PaginationHelper
  def custom_paginate(collection, per_page: 10)
    # Get current page from params or default to 1
    current_page = params[:page].to_i.positive? ? params[:page].to_i : 1

    # Calculate total pages
    total_pages = (collection.size.to_f / per_page).ceil

    # Paginate collection
    paginated_collection = collection.offset((current_page - 1) * per_page).limit(per_page)

    # Return paginated collection and page data
    {
      collection: paginated_collection,
      current_page: current_page,
      total_pages: total_pages
    }
  end

  def pagination_links(current_page, total_pages)
    content_tag :nav, class: "pagination" do
      safe_join([
        previous_page_link(current_page),
        page_number_links(current_page, total_pages),
        next_page_link(current_page, total_pages)
      ])
    end
  end

  private

  # Link to the previous page
  def previous_page_link(current_page)
    link_to("« Previous", params.permit(:page).merge(page: current_page - 1), class: "page-link #{'disabled' if current_page <= 1}")
  end

  # Link to the next page
  def next_page_link(current_page, total_pages)
    link_to("Next »", params.permit(:page).merge(page: current_page + 1), class: "page-link #{'disabled' if current_page >= total_pages}")
  end

  # Display surrounding page numbers
  def page_number_links(current_page, total_pages)
    window_size = 7
    half_window = window_size / 2

    # Set the start and end range
    start_page = [current_page - half_window, 1].max
    end_page = [start_page + window_size - 1, total_pages].min

    # Adjust start if we're near the end
    start_page = [end_page - window_size + 1, 1].max

    # Generate page links
    (start_page..end_page).map do |page|
      link_to(page, params.permit(:page).merge(page: page), class: "page-link #{'active' if page == current_page}")
    end.join.html_safe
  end
end

