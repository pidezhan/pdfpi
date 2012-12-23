class HomeController < ApplicationController
	def index
		@doc_path = File.join(Rails.root, 'public', 'pdf')
		
		respond_to do |format|
			format.html
			format.pdf do
				require 'prawn'
				pdf = Prawn::Document.new
				pdf.text "Hello world!"
				pdf.start_new_page(:template => @doc_path + "/lfs.pdf", :template_page => 2)
				pdf.start_new_page(:template => @doc_path + "/chart.pdf")
				
				send_data pdf.render, filename: "hello.pdf", type: "application/pdf"
			end
		end
		
	end
	
	def combine
	  session['combine_job_id'] ||= get_job_id
	  @uploads = Upload.where(:job_id => session['combine_job_id'])
	  @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')

	  if request.post? and @uploads.size > 0
	    require 'prawn'
      pdf = Prawn::Document.new(:skip_page_creation => true)
	    @uploads.each do |upload|
	      page_count = 0
	      file_path = @doc_path + "/" + upload.id.to_s + "/original/" + upload.upload_file_name
	      page_count = Prawn::Document.new(:template => file_path ).page_count
	      (1..page_count).each do |n|
	        pdf.start_new_page(:template => file_path, :template_page => n)
	      end
	    end
	    
	    send_data pdf.render, filename: "combined_into_one.pdf", type: "application/pdf"
	  end
	end
	
	def deliver
	  
	  @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')

	  if request.post? and params['job'] == 'combine'
	    @uploads = Upload.where(:job_id => session['combine_job_id'])
	    if session['combine_job_id'] and @uploads.size > 0
	      @download_path = File.join(Rails.root, 'public', 'system', 'downloads', session['combine_job_id'])
	      file_name = "combined_into_one.pdf"
	      require 'prawn'
        pdf = Prawn::Document.new(:skip_page_creation => true)
  	    @uploads.each do |upload|
  	      page_count = 0
  	      file_path = @doc_path + "/" + upload.id.to_s + "/original/" + upload.upload_file_name
  	      page_count = Prawn::Document.new(:template => file_path ).page_count
  	      (1..page_count).each do |n|
  	        pdf.start_new_page(:template => file_path, :template_page => n)
  	      end
  	    end
  	    
  	    require 'fileutils'
  	    FileUtils.mkpath @download_path
  	    
  	    @download_link = File.join('system', 'downloads', session['combine_job_id'], file_name)

        pdf.render_file(File.join( @download_path, file_name) )
        @uploads.delete_all
  	    #send_data pdf.render, filename: "combined_into_one.pdf", type: "application/pdf"
  	    
  	    # reset session['combine_job_id']
  	    session['combine_job_id'] = nil
	    else
	      flash[:error] = "No PDF documents to combine"
	      redirect_to :action => 'combine'
	    end
	  else
	    flash[:info] = "Combine PDF documents from here"
	    redirect_to :action => 'combine'
	  end

	end
	
	def sort
	  session['combine_job_id'] ||= get_job_id
	  @uploads = Upload.where(:job_id => session['combine_job_id'])
	  @uploads.each do |upload|
      upload.position = params['upload'].index(upload.id.to_s) + 1
      upload.save
    end

    render :nothing => true
	end
	
	def split
	  session['split_job_id'] ||= get_job_id
	  @upload = Upload.where(:job_id => session['split_job_id']).order('updated_at desc').first
	  
	end
	
	def deliver_split
	  if request.post?
	    @upload = Upload.where(:job_id => session['split_job_id']).order('updated_at desc').first
	    if session['split_job_id'] and @upload
	      @download_path = File.join(Rails.root, 'public', 'system', 'downloads', session['split_job_id'])
	      download_file_name = "split1.pdf"
	      require 'prawn'
  	    @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')
  	    file_path = @doc_path + "/" + @upload.id.to_s + "/original/" + @upload.upload_file_name
  	    range1_from = params[:range1_from].to_i
  	    range1_to = params[:range1_to].to_i
	    
  	    if range1_from > 0 and range1_to > 0 and range1_to >= range1_from
  	      pdf = Prawn::Document.new(:skip_page_creation => true)
  	      if range1_to >= range1_from
  	        ((range1_from)..range1_to).each do |n|
  	          pdf.start_new_page(:template => file_path, :template_page => n)
            end
  	      end
  	    end
  	    
  	    require 'fileutils'
  	    FileUtils.mkpath @download_path
  	    @download_link = File.join('system', 'downloads', session['split_job_id'], download_file_name)
	    
  	    pdf.render_file(File.join(@download_path, download_file_name))
  	    
  	    # reset session
  	    Upload.where(:job_id => session['split_job_id']).delete_all
  	    session['split_job_id'] = nil
  	  else
  	    flash[:error] = "No PDF to split"
  	    redirect_to :action => 'split'
  	  end
  	else
  	  flash[:info] = "Split PDF from here"
	    redirect_to :action => 'split'
	  end
	end
	
end
