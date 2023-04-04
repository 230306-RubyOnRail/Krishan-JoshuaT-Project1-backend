require_relative './concerns/authentication_concern'
class ReimbursementController < ApplicationController
  include Authentication_Concern

  def create
    # need to add checks to see if all the null fields are filled

    # makes new reimbursement
    @reimbursement = Reimbursement.new(reimburse_params)
    # checks if the user_id in the reimbursement is the same as the user_id in the token

      # if the reimbursement is valid, save it and return a success message
    if @reimbursement.save
      render status: 200, json: { message: "Reimbursement request made successfully" }
      # if the reimbursement is not valid, return an error message
    else
      render status: 400, json: { message: "Invalid" }
    end

  end

  def index
    @reimbursement = Reimbursement.all
    render json: @reimbursement
  end

  def show
    if params[:authorization][0][:account_type] == "manager"
      reimbursements = Reimbursement.where(user_id: params[:id])
      render status: 200, json: {message: reimbursements}
    else
      render status: 400, json: {message: "You are not authorized"}
      end
  end

  def delete
    reimbursement = Reimbursement.find(params[:id])
    if params[:authorization][0][:account_type] == "manager"
      reimbursement.destroy if reimbursement != nil
      render status: 200, json: {message: "Reimbursement request deleted successfully"}
    elsif params[:authorization][0][:account_type] == "employee" && params[:authorization][0][:user_id] == reimbursement.user_id
      reimbursement.destroy if reimbursement != nil
      render status: 200, json: {message: "Reimbursement request deleted successfully"}
    else
      render status: 400, json: {message: "You are not authorized"}
    end
  end

  def update
    reimbursement = Reimbursement.find(params[:id])
    if params[:authorization][0][:account_type] == "manager"
      reimbursement.update(reimburse_params)
      render status: 200, json: {message: "Reimbursement request updated successfully"}
    elsif params[:authorization][0][:account_type] == "employee" && params[:authorization][0][:user_id] == reimbursement.user_id
      reimburse_params[:user_id] = params[:authorization][0][:user_id] # to force the user_id to be the same as the token
      reimbursement.update(reimburse_params)
      render status: 200, json: {message: "Reimbursement request updated successfully"}
    else
      render status: 400, json: {message: "You are not authorized"}
    end
  end

  # returns the reimbursement params that are allowed to be passed in

  private

  def reimburse_params
    params[:reimbursement][:user_id] = params[:authorization][0][:user_id]
    params.require(:reimbursement).permit(:description, :amount, :status, :user_id)
  end

  # adds the authorization header to the params
  # this is used to get the user_id from the token
  # this is used to check if the user_id in the reimbursement is the same as the user_id in the token


  # def authorization
  #   token = request.env["HTTP_AUTHORIZATION"].split(" ")
  #   token = token[1]
  #   jwt = Jwt_Session.decode(token)[0]
  # end
end
