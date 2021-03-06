# frozen_string_literal: true

class VolunteersController < ApplicationController

before_action :authenticate_user!
after_action  :verify_authorized
before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    # set permission that only the administrator can see the index
    # also set up function/action either here or in devise that when the user
    # first sign up for login credentials they're redirected to a creat your
    # profile page.
    @volunteer = Volunteer.all
    authorize Volunteer
  end

  def new
    if current_user.volunteer.nil?
      @volunteer = current_user.build_volunteer
    else
      @volunteer = current_user.volunteer
      redirect_to volunteer_path(@volunteer)
    end
    authorize @volunteer
  end

  def create
    if current_user.volunteer.nil?
      @volunteer = current_user.build_volunteer(volunteer_params)
    else
      redirect_to volunteer_path(current_user.volunteer)
    end
    authorize @volunteer
    if @volunteer.save
      flash[:success] = "Volunteer created."
      redirect_to volunteer_path(@volunteer)
    else
      render 'new'
    end
  end

  def show
    authorize @volunteer
  end

  def edit
    authorize @volunteer
  end

  def update
    authorize @volunteer
    if @volunteer.update_attributes(volunteer_params)
      flash[:success] = "Volunteer updated."
      redirect_to volunteer_path(@volunteer)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @volunteer
    @volunteer.destroy
    flash[:success] = "Volunteer deleted."
    redirect_to root_path
  end

  # def (action to view projects)
  #   # show projects available based on their skills?
  #   # show past projects they've completed?
  #   # show current projects and profiles for their team members?
  # end

  def add
    # for volunteer to sign up for a project
    # if volunteer signs up, a message or notification gets sent to the administrator
  end

  def remove
    # for volunteer to remove project, perhaps include a note for why they're
    # no longer available?
  end

  def added_repairs
    @repairs = Repair.all
    if current_user.nil?
      redirect_to new_volunteer_path
    else
      @volunteer = current_user.volunteer
    end
    authorize @volunteer
  end

  def add_repair
    @volunteer_repair = VolunteerRepair.new
    if current_user.volunteer.nil?
      redirect_to new_volunteer_path
    else
      @volunteer_repair.volunteer_id = current_user.volunteer.id
      @volunteer_repair.repair_id = params[:id]
      @volunteer_repair.status = 'Pending'
      skip_authorization
    end

    if @volunteer_repair.save
      flash[:success] = "Repair added."
      redirect_to added_repairs_volunteers_path
    else
      flash[:success] = "Repair not added."
    end
  end

  def remove_repair
    @volunteer_repair = VolunteerRepair.find(params[:id])
    @volunteer_repair.volunteer_id = current_user.volunteer.id
    skip_authorization

    @volunteer_repair.destroy
    flash[:success] = "Repair removed."
    redirect_to added_repairs_volunteers_path
  end

  private
      def volunteer_params
        params.require(:volunteer).permit(:picture,:first_name,:last_name,:email,
                                          :mobile_phone, :birthdate, :gender, :city,
                                          :state, :employer, :position,:avail_sun_am,
                                          :avail_sun_pm, :avail_mon_am, :avail_mon_pm,
                                          :avail_tue_am, :avail_tue_pm, :avail_wed_am,
                                          :avail_wed_pm, :avail_thr_am, :avail_thr_pm,
                                          :avail_fri_am, :avail_fri_pm, :avail_sat_am,
                                          :avail_sat_pm, :skill, :volunteer_notes)
      end

      def set_volunteer
        if current_user.admin?
          @volunteer = Volunteer.find(params[:id])
        else
          @volunteer = current_user.volunteer
        end
      end
end
