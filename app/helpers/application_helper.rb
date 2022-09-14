module ApplicationHelper
  def concat_address(address)
    "#{address.street_address}, #{address.barangay.name}, #{address.city.name}, #{address.province.name}, #{address.region.name}"
  end

  def banners
    Banner.active.where("DATE(online_at) <= ?", Time.now).where("DATE(offline_at) > ?", Time.now)
  end

  def news_ticker
    NewsTicker.active.limit(5)
  end

end
