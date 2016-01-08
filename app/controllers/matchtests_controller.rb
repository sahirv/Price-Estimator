class MatchtestsController < ApplicationController
  before_action :set_matchtest, only: [:show, :edit, :update, :destroy]

  # GET /matchtests
  # GET /matchtests.json
  def index
    @matchtests = Matchtest.all
  end

  # GET /matchtests/1
  # GET /matchtests/1.json
  def show
  end

  # GET /matchtests/new
  def new
    @matchtest = Matchtest.new
  end

  # GET /matchtests/1/edit
  def edit
  end

  # POST /matchtests
  # POST /matchtests.json
  def create
    @matchtest = Matchtest.new(matchtest_params)

    respond_to do |format|
      if @matchtest.save
        format.html { redirect_to @matchtest, notice: 'Matchtest was successfully created.' }
        format.json { render :show, status: :created, location: @matchtest }
      else
        format.html { render :new }
        format.json { render json: @matchtest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matchtests/1
  # PATCH/PUT /matchtests/1.json
  def update
    respond_to do |format|
      if @matchtest.update(matchtest_params)
        format.html { redirect_to @matchtest, notice: 'Matchtest was successfully updated.' }
        format.json { render :show, status: :ok, location: @matchtest }
      else
        format.html { render :edit }
        format.json { render json: @matchtest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matchtests/1
  # DELETE /matchtests/1.json
  def destroy
    @matchtest.destroy
    respond_to do |format|
      format.html { redirect_to matchtests_url, notice: 'Matchtest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matchtest
      @matchtest = Matchtest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def matchtest_params
      params[:matchtest]
    end
end
