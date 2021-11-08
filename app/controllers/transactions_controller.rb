class TransactionsController < ApplicationController
  def index
    records = Transaction.all
    @transactions = LoadModelService.new(records, searchable_params)
    @transactions.call

    if @transactions.records.empty?
      render json: '[]'
    else
      render json: @transactions.records, meta: pagination_dict(@transactions.records)
    end
  end

  private

  def searchable_params
    params.permit({ search: {} }, { page: {} }, { order: {} }, { transaction: {} })
  end
end
