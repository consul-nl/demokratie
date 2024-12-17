class DeficiencyReportManagement::DistrictsController < DeficiencyReportManagement::BaseController
  # load_and_authorize_resource :district, class: "RegisteredAddress::District"
  skip_authorization_check only: :index

  def index
    @districts = RegisteredAddress::District.all
  end
end
