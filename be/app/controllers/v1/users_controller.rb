# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :load_user, only: [:show, :update, :destroy, :events, :join_event, :leave_event]
    # GET /v1/users
    def index
      users = User.all
      render json: users.to_json
    end

    # GET /v1/users/:id
    def show
      user = User.find(params[:id])
      render json: user.to_json
    end

    # POST /v1/users
    def create
      user = User.new(user_params)

      if user.save
        render json: user.to_json
      else
        render json: user.errors.to_json
      end
    end

    # PATCH /v1/users/:id
    def update
      user = User.find(params[:id])

      if user.update(user_params)
        render json: user.to_json
      else
        render json: user.errors.to_json
      end
    end

    # DELETE /v1/users/:id
    def destroy
      user = User.find(params[:id])
      user.destroy

      render json: user.to_json
    end

    # GET /v1/users/:id/events
    def events
      render json: @user.events.to_json
    end

    # POST /v1/users/:id/events
    def join_event
      event = Event.find(params[:event_id])
      attendee = Attendee.new(event: event, user: @user)

      if attendee.save
        render json: event.to_json
      else
        render json: attendee.errors.to_json
      end
    end

    # DELETE /v1/users/:id/events/:event_id
    def leave_event
      event = Event.find(params[:event_id])
      attendee = Attendee.find_by(event: event, user: @user)
      attendee.destroy

      render json: event.to_json
    end

    private

    def load_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_address)
    end
  end
end
