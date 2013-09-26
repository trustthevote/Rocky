class FileservingController < ApplicationController
  def partner_logo
    id = [params[:id1],params[:id2],params[:id3]].join.to_i
    
    file_name=Rails.root.join("public/system/logos/#{id}/#{params[:style]}/#{params[:filename]}.#{params[:ext]}")
     
    send_file file_name, :disposition => 'inline'
  end
end