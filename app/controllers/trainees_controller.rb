class TraineesController < ApplicationController
  before_action :set_trainee, only: %i[show edit update destroy]

  # GET /trainees or /trainees.json
  def index
    @trainees = Trainee.all
  end

  # GET /trainees/1 or /trainees/1.json
  def show
  end

  # GET /trainees/new
  def new
    @trainee = Trainee.new
  end

  # GET /trainees/1/edit
  def edit
  end

  # POST /trainees or /trainees.json
  def create
    @trainee = Trainee.new(trainee_params)

    respond_to do |format|
      if @trainee.save
        format.html { redirect_to trainee_url(@trainee), notice: "Trainee was successfully created." }
        format.json { render :show, status: :created, location: @trainee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @trainee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trainees/1 or /trainees/1.json
  def update
    respond_to do |format|
      if @trainee.update(trainee_params)
        format.html { redirect_to trainee_url(@trainee), notice: "Trainee was successfully updated." }
        format.json { render :show, status: :ok, location: @trainee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @trainee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trainees/1 or /trainees/1.json
  def destroy
    @trainee.destroy

    respond_to do |format|
      format.html { redirect_to trainees_url, notice: "Trainee was successfully destroyed." }
      format.json { head :no_content }
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
end
