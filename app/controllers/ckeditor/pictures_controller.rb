# frozen_string_literal: true

class Ckeditor::PicturesController < ApplicationController
  def create
    picture = Ckeditor::Picture.new
    authorize! :create, picture
    picture.attach_uploaded_file(params[:upload])

    if picture.save
      render json: picture.attributes.symbolize_keys.slice(*allowed_attributes).merge(
        url: picture.url_content(editor_id: params[:editor_id]),
        thumb_url: picture.url_thumb
      )
    else
      render json: { error: { message: picture.errors.messages.values.flatten.join(", ") }}
    end
  end

  def update
    picture = Ckeditor::Picture.find(params[:id])
    authorize! :update, picture
    picture.update!(picture_params)
    render json: picture.attributes.symbolize_keys.slice(*allowed_attributes).merge(
      url: picture.url_content(editor_id: params[:editor_id]),
      thumb_url: picture.url_thumb
    )
  end

  def destroy
    picture = Ckeditor::Picture.find(params[:id])
    authorize! :destroy, picture
    picture.destroy!
    render json: { status: :no_content }
  end

  private

    def picture_params
      params.require(:picture).permit(:title, :description, :alt_text)
    end

    def allowed_attributes
      %i[id data_file_name data_content_type data_file_size width height created_at title description alt_text url thumb_url]
    end
end
