module LotteryHelper
  def progress(item)
    [(item.bets.where(batch_count: item.batch_count).count.to_f/item.minimum_bets.to_f) * 100, 100].min.to_i
  end
end