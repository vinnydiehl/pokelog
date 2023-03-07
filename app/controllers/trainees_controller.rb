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

    # The behavior defaults to gen 9 throughout most of the UI
    @generation = cookies[:generation] ? cookies[:generation].to_i : 9

    [[3, /power/],
     [7, /macho_brace/]].each do |disabled_gen, pattern|
      if @generation == disabled_gen
        @party.each do |trainee|
          if trainee.item =~ pattern
            trainee.item = nil
            trainee.save!
          end
        end
      end
    end

    # Search uses the cookie, if there is none set it will not filter
    @search_results = Species.search params, cookies[:generation]
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
      redirect_to "#{trainee_path("#{params[:ids]},#{@trainee.id}")}?#{request.query_parameters.to_query}"
    else
      flash[:notice] = PROBLEM_CREATING_NOTICE
      redirect_back fallback_location: root_path
    end
  end

  # GET /trainees/:ids/delete
  def delete_multi
    params[:ids].split(",").map { |id| Trainee.find id }.each do |trainee|
      if allowed_to_edit? trainee
        trainee.destroy
        # ||= that way the "not yours" notice sticks if it is triggered
        flash[:notice] ||= "Trainees deleted."
      else
        flash[:notice] = "Not your trainee!"
      end
    end

    redirect_back fallback_location: root_path
  end

  # PATCH/PUT /trainees/1
  def update
    if allowed_to_edit? @trainee
      respond_to do |format|
        @trainee.set_attributes params["trainee"]
        @trainee.save!

        titles = helpers.trainees_show_title(JSON.parse params[:trainees])
        radar_id = "radar-chart-#{helpers.dom_id @trainee}"
        dom_id = helpers.dom_id @trainee

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("title", html: titles[:title]),
            turbo_stream.update("title-mobile", html: titles[:mobile_title]),
            turbo_stream.update("trainee-title-#{dom_id}", html: @trainee.title),
            turbo_stream.update("artwork-#{dom_id}",
                                partial: "trainees/artwork", locals: {trainee: @trainee}),
            turbo_stream.update(radar_id, partial: "shared/radar_chart",
                                locals: {stats: @trainee.evs, goals: @trainee.goals,
                                         id: radar_id}),
            turbo_stream.update("mobile-sprite-#{dom_id}", html:
                                @trainee.species ? @trainee.species.sprite : nil),
            turbo_stream.update(
              "types-#{dom_id}",
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
      id, nickname = @trainee.id, @trainee.nickname
      nickname = "Trainee" if nickname.blank?

      @trainee.destroy

      # Regex removes the targeted ID from comma-separated list. Redirect to trainees#index if only 1
      redirect_path = !params["redirect_path"].include?(",") ? trainees_path :
        params["redirect_path"].sub(/\b#{id}\b,|,\b#{id}\b(?=$|\?)/, "") + params["redirect_params"]

      respond_to do |format|
        format.html { redirect_to redirect_path, status: :see_other,
                                                 notice: "#{nickname} has been deleted." }
      end
    else
      flash[:notice] = NOT_YOURS_NOTICE
      redirect_back fallback_location: root_path
    end
  end

  # POST /trainees/paste
  def paste
  end

  # POST /trainees/paste/fetch
  def fetch
    begin
      paste = PokePaste.fetch(params[:url]).to_s
      render plain: paste
    rescue
      head :not_found
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
