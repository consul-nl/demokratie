class Officing::OfflineBallotsController < Officing::BaseController
  include OfficingActions

  def investments
    @user = User.find(params[:user_id])
    @budget = Budget.find(params[:budget_id])
    @heading = @budget.heading
    @ballot = Budget::Ballot.where(user: @user, budget: @budget).first_or_create!(conditional: false, physical: true)
    @investments = @budget.investments.selected
    @investment_ids = @investments.ids
  end
end
