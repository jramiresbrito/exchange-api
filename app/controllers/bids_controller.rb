class BidsController < ApplicationController
  def index
    records = Bid.all
    @bids = LoadModelService.new(records, searchable_params)
    @bids.call

    if @bids.records.empty?
      render json: '[]'
    else
      render json: @bids.records, meta: pagination_dict(@bids.records)
    end
  end

  private

  def searchable_params
    params.permit({ search: {} }, { page: {} }, { order: {} }, { bid: {} })
  end
end
