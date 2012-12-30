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
	      require 'prawn'
  	    @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')
  	    file_path = @doc_path + "/" + @upload.id.to_s + "/original/" + @upload.upload_file_name
  	    ranges = []
  	    range1_from, range1_to = 0,0
  	    range2_from, range2_to = 0,0
  	    range3_from, range3_to = 0,0
  	    range4_from, range4_to = 0,0
  	    range5_from, range5_to = 0,0
  	    range6_from, range6_to = 0,0
  	    range7_from, range7_to = 0,0
  	    range8_from, range8_to = 0,0
  	    range9_from, range9_to = 0,0
  	    range10_from, range10_to = 0,0
  	    (1..10).each do |n|
  	      eval "range#{n}_from = params[:range#{n}_from].to_i"
    	    eval "range#{n}_to = params[:range#{n}_to].to_i"
    	    eval "if valid_range(range#{n}_from, range#{n}_to); ranges << {:from => range#{n}_from, :to => range#{n}_to};end"
	      end
	      
	      @download_folder = File.join(Rails.root, 'public', 'system', 'downloads', session['split_job_id'])
	      download_file_name = "pdfPi.com_PDF_splits.zip"
  	    @download_link = File.join('system', 'downloads', session['split_job_id'], download_file_name)
        # create folder
  	    require 'fileutils'
  	    FileUtils.mkpath @download_folder
        
	      input_filenames = []
	      ranges = ranges.uniq
	      n = 1
  	    ranges.each do |range|
  	      pdf = Prawn::Document.new(:skip_page_creation => true)
	        (range[:from]..range[:to]).each do |n|
	          pdf.start_new_page(:template => file_path, :template_page => n)
	        end
	        pdf.render_file(File.join(@download_folder, "split_#{n.to_s}.pdf"))
	        input_filenames << "split_#{n.to_s}.pdf"
	        n += 1
  	    end
  	    
  	    @ranges = ranges
  	    
  	    # generate zip file
  	    require 'rubygems'
        require 'zip/zip'

        zipfile_name = @download_folder + "/" + download_file_name

        Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
          input_filenames.each do |filename|
            # Two arguments:
            # - The name of the file as it will appear in the archive
            # - The original file, including the path to find it
            zipfile.add(filename, @download_folder + '/' + filename)
          end
        end

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
	
private
  def valid_range(from, to)
    from > 0 and to > 0 and to >= from
  end
	
end
