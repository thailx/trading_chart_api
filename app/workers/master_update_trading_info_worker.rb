class MasterUpdateTradingInfoWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, queue: 'critical'

  def perform(*args)
    # Do something
    count_crypto = Crytocurrency.count
    total_pages = (count_crypto / 10) + 1
    total_pages.times do |i|
      offset = i * 10
      UpdateCryptoTradingInfoWorker.perform_in(offset.minutes.from_now, offset)
    end
  end
end