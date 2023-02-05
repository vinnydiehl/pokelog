class TraineesController < ApplicationController
  before_action :set_trainee, only: %i[update destroy]

  NO_USER_NOTICE = "Not logged in."
  NOT_YOURS_NOTICE = "Not your trainee!"
  PROBLEM_CREATING_NOTICE = "There was a problem creating a trainee."

  # GET /trainees
  def index
    return redirect_to root_path, notice: NO_USER_NOTICE if @current_user.blank?
    @trainees = Trainee.where(user: @current_user).order(updated_at: :desc)
  end

  # GET /trainees/1 or /trainees/1,2,3
  def show
    @ids = params[:ids].split(",").map &:to_i
    @party = Trainee.where(id: @ids)
    @other_trainees = Trainee.where(user: @current_user).where.not(id: @ids)

    render "errors/not_found", status: 404 if @party.empty?

    @nil_nature_option = ["Nature", ""]
    @nature_options = YAML.load_file("data/natures.yml").keys.sort.map do |n|
      [n.capitalize, n]
    end

    @items_options = YAML.load_file("data/items.yml").keys

    @search_results = Species.search params
  end

  # GET /trainees/new
  def new
    return redirect_to root_path, notice: NO_USER_NOTICE if @current_user.blank?
    @trainee = Trainee.new(user: @current_user)

    notice = @trainee.save ? nil : PROBLEM_CREATING_NOTICE
    redirect_to trainee_path(@trainee), notice: notice
  end

  # GET /trainees/:ids/new
  def add_new
    return redirect_to trainee_path(params[:ids]), notice: NO_USER_NOTICE if @current_user.blank?
    @trainee = Trainee.new(user: @current_user)
    if @trainee.save
      redirect_to trainee_path("#{params[:ids]},#{@trainee.id}")
    else
      flash[:notice] = PROBLEM_CREATING_NOTICE
      redirect_back fallback_location: root_path
    end
  end

  # PATCH/PUT /trainees/1
  def update
    if allowed_to_edit? @trainee
      respond_to do |format|
        @trainee.set_attributes params["trainee"]
        @trainee.save!

        titles = helpers.trainees_show_title(JSON.parse params[:trainees])
        radar_id = "radar-chart-#{helpers.dom_id @trainee}"

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("title", html: titles[:title]),
            turbo_stream.update("title-mobile", html: titles[:mobile_title]),
            turbo_stream.update("artwork-#{helpers.dom_id @trainee}",
                                partial: "trainees/artwork", locals: {trainee: @trainee}),
            turbo_stream.update(radar_id, partial: "shared/radar_chart",
                                locals: {stats: @trainee.evs, id: radar_id}),
            turbo_stream.update("mobile-sprite-#{helpers.dom_id @trainee}", html:
                                @trainee.species ? @trainee.species.sprite : nil),
            turbo_stream.update(
              "types-#{helpers.dom_id @trainee}",
              html: @trainee.species ? @trainee.species.type_badges(size: :large) : nil
            )
          ]
        end
      end
    else
      flash[:notice] = NOT_YOURS_NOTICE
      redirect_back fallback_location: root_path
    end
  end

  # DELETE /trainees/1
  def destroy
    if allowed_to_edit? @trainee
      nickname = @trainee.nickname
      nickname = "Trainee" if nickname.blank?

      @trainee.destroy

      respond_to do |format|
        format.html { redirect_to trainees_url, status: :see_other,
                        notice: "#{nickname} has been deleted." }
      end
    else
      flash[:notice] = NOT_YOURS_NOTICE
      redirect_back fallback_location: root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trainee
      @trainee = Trainee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def trainee_params
      params.require(:trainee).permit(:user_id, :team_id, :species_id, :level, :pokerus, :start_stats, :trained_stats, :kills, :nature, :evs)
    end

    # Authentication for trainee modification
    def allowed_to_edit?(trainee)
      !@current_user.blank? && @current_user == trainee.user
    end
end
