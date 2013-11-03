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
	
	def why_us
	end
	
	def combine
	  session['combine_job_id'] ||= get_job_id
	  @uploads = Upload.where(:job_id => session['combine_job_id'])
	  @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')
	  Job.create(:session_id => session['combine_job_id'], :job_type => "combine", :source_ip => request.remote_ip, :status => 'in progress') if not Job.find_by_session_id(session['combine_job_id'])

	  if request.post? and @uploads.size > 0
=begin
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
=end
	  end
	end
	
	def deliver # delivery combine
	  
	  @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')

	  if request.post? and params['job'] == 'combine'
	    @uploads = Upload.where(:job_id => session['combine_job_id'])
	    if session['combine_job_id'] and @uploads.size > 1
	      @download_path = File.join(Rails.root, 'public', 'system', 'downloads', session['combine_job_id'])
	      file_name = "pdfpi.com.combined_into_one.pdf"
=begin
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
=end
  	    file_list = ""
        @uploads.each do |upload|
          file_list = file_list + @doc_path + "/" + upload.id.to_s + "/original/" + upload.upload_file_name + " "
        end
        require 'fileutils'
  	    FileUtils.mkpath @download_path
  	    
  	    # action!!
  	    command = "java -jar #{pdfbox_jar} PDFMerger #{file_list} #{File.join( @download_path, file_name)}"
        system command
  	    
  	    # Rails.logger.debug("command: #{command.inspect}")
        
  	    @download_link = File.join('system', 'downloads', session['combine_job_id'], file_name)

        #pdf.render_file(File.join( @download_path, file_name) )
        
        # remove all upload files related to this job
        @uploads.each do | upload |
          file_path = @doc_path + "/" + upload.id.to_s + "/original/" + upload.upload_file_name
          #FileUtils.rm file_path
        end
        
        
  	    #send_data pdf.render, filename: "combined_into_one.pdf", type: "application/pdf"
  	    @job = Job.order('id desc').find_by_session_id(session['combine_job_id'])
  	    if @job
  	      @job.download_path = @download_path + "/" + file_name
  	      @job.download_link = @download_link
  	      @job.expiry_date = Time.now + 7.days
  	      @job.status = (File.exist?(@job.download_path) ? "OK" : "ERROR" )
  	      @job.save
  	    end
  	    
  	    #@uploads.delete_all
  	    # reset session['combine_job_id']
  	    session['combine_job_id'] = nil
  	    
  	    #flash[:success] = "Congratulations! Your pdf documents have been processed successfully!"
	      redirect_to :controller => 'jobs', :action => 'show', :id => @job.session_id
	    else
	      flash[:error] = "Sorry, too few PDF documents are uploaded. We need at least 2 pdfs uploaded before combining."
	      redirect_to :action => 'combine'
	    end
	  else
	    flash[:info] = "Combining PDF documents starts from this page."
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
	  Job.create(:session_id => session['split_job_id'], :job_type => "split", :source_ip => request.remote_ip, :status => 'in progress') if not Job.find_by_session_id(session['split_job_id'])
    
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
=begin
  	      pdf = Prawn::Document.new(:skip_page_creation => true)
	        (range[:from]..range[:to]).each do |page|
	          pdf.start_new_page(:template => file_path, :template_page => page)
	        end
	        pdf.render_file(File.join(@download_folder, "split_#{n.to_s}.pdf"))
	        input_filenames << File.join(@download_folder, "split_#{n.to_s}.pdf")
	        
=end
          # action!!
    	    command_split = "java -jar #{pdfbox_jar} PDFSplit -startPage #{range[:from]} -endPage #{range[:to]} #{file_path}"
    	    Rails.logger.debug("command split: #{command_split.inspect}")
          system command_split
          split_file_name = File.join(@download_folder, "/pdfpi.com.split" + n.to_s + ".pdf")
          command_mv = "mv #{file_path[0..file_path.length-5] + "-0.pdf"} #{split_file_name}"
          Rails.logger.debug("command mv: #{command_mv.inspect}")
          system command_mv
          input_filenames << split_file_name
          n += 1
  	    end


  	    zipfile_name = @download_folder + "/" + download_file_name
  	    
  	    # generate zip file
  	    
  	    `zip -j #{zipfile_name} #{input_filenames.join(' ')}`
=begin
        require 'rubygems'
        require 'zip/zip'
        
        

        Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
          input_filenames.each do |filename|
            # Two arguments:
            # - The name of the file as it will appear in the archive
            # - The original file, including the path to find it
            zipfile.add(filename, @download_folder + '/' + filename)
          end
        end
=end

  	    # reset session
  	    
  	    #remove all upload files related to this job
  	    @uploads = Upload.where(:job_id => session['split_job_id'])
        @uploads.each do | upload |
          file_path = @doc_path + "/" + upload.id.to_s + "/original/" + upload.upload_file_name
          #FileUtils.rm file_path
        end
        
        @job = Job.where(:session_id => session['split_job_id']).order('id desc').first
  	    if @job
  	      @job.download_path = zipfile_name
  	      @job.download_link = @download_link
  	      @job.expiry_date = Time.now + 7.days
  	      @job.status = (File.exist?(@job.download_path) ? "OK" : "ERROR" )
  	      @job.save
  	    end
        
  	    #@uploads.delete_all
  	    session['split_job_id'] = nil
  	    
  	    #flash[:success] = "Congratulations! Your pdf documents have been processed successfully!"
	      redirect_to :controller => 'jobs', :action => 'show', :id => @job.session_id
  	  else
  	    flash[:error] = "No PDF to split"
  	    redirect_to :action => 'split'
  	  end
  	else
  	  flash[:info] = "Split PDF from here"
	    redirect_to :action => 'split'
	  end
	end
	
	def stamp
	  @fonts = [
	    "Arial",
	    "Calibri",
	    "Courier",
	    "Helvetica",
	    "Times New Roman",
	    "Verdana"
	    ]
	    
	    session['stamp_job_id'] ||= get_job_id
  	  @upload = Upload.where(:job_id => session['stamp_job_id']).order('updated_at desc').first
  	  Job.create(:session_id => session['stamp_job_id'], :job_type => "stamp", :source_ip => request.remote_ip, :status => 'in progress') if not Job.find_by_session_id(session['stamp_job_id'])
      
	end
	
	def deliver_stamp
	  if request.post?
	    @upload = Upload.where(:job_id => session['stamp_job_id']).order('updated_at desc').first
	    if session['stamp_job_id'] and @upload
	      require 'prawn'
  	    @doc_path = File.join(Rails.root, 'public', 'system', 'uploads')
  	    file_path = @doc_path + "/" + @upload.id.to_s + "/original/" + @upload.upload_file_name
	      
	      @download_folder = File.join(Rails.root, 'public', 'system', 'downloads', session['stamp_job_id'])
	      download_file_name = "pdfPi.com_stamped_#{@upload.upload_file_name}"
  	    @download_link = File.join('system', 'downloads', session['stamp_job_id'], download_file_name)
        # create folder
  	    require 'fileutils'
  	    FileUtils.mkpath @download_folder
        
        width = 100
        height = 50
        pdf = Prawn::Document.new(:template => file_path)
        x = pdf.bounds.left + 3
        y = pdf.bounds.top - 3
  	    pdf.create_stamp("user_stamp") do
  	      pdf.fill_color params[:font_color].gsub('#','')
  	      pdf.font get_font(params[:font])
  	      #pdf.stroke_rectangle [x, y], width, height
  	      pdf.transparent(params[:font_opacity].to_f) do
	          pdf.text(params[:text], :size => params[:font_size].to_i, 
	            :align => (params[:h_align] == "left" ? :left : (params[:h_align] == "center" ? :center : :right)), 
	            :valign => (params[:v_align] == "top" ? :top : (params[:v_align] == "center" ? :center : :bottom)))
	        end
  	    end
    	  
    	  pdf.repeat(:all) do
    	    pdf.stamp "user_stamp"
    	  end
    	  
  	    pdf.render_file(File.join( @download_folder, download_file_name) )
  	    
  	    # reset session
  	    #remove all upload files related to this job
  	    @uploads = Upload.where(:job_id => session['stamp_job_id'])
        @uploads.each do | upload |
          file_path = @doc_path + "/" + upload.id.to_s + "/original/" + upload.upload_file_name
          #FileUtils.rm file_path
        end
        
        @job = Job.where(:session_id => session['stamp_job_id']).order('id desc').first
  	    if @job
  	      @job.download_path = File.join( @download_folder, download_file_name)
  	      @job.download_link = @download_link
  	      @job.expiry_date = Time.now + 7.days
  	      @job.status = (File.exist?(@job.download_path) ? "OK" : "ERROR" )
  	      @job.save
  	    end
  	    
  	    #@uploads.delete_all
  	    session['stamp_job_id'] = nil
  	    
  	    #flash[:success] = "Congratulations! Your pdf documents have been processed successfully!"
	      redirect_to :controller => 'jobs', :action => 'show', :id => @job.session_id
	      
  	  else
  	    flash[:error] = "No PDF to stamp"
  	    redirect_to :action => 'stamp'
  	  end
  	else
  	  flash[:info] = "Stamp PDF from here"
	    redirect_to :action => 'stamp'
	  end
	end
	
	def download
	  @job = Job.find_by_session_id(params['job_id'])
	end
	
private
  def valid_range(from, to)
    from > 0 and to > 0 and to >= from
  end
  
  def get_font(font_name)
    font_location = File.join(Rails.root, 'config', 'fonts')
    font_hash = {}
    font_hash['Arial'] = File.join(font_location, 'Arial.ttf')
    font_hash['Calibri'] = File.join(font_location, 'Calibri.ttf')
    font_hash['Courier'] = "Courier"
    font_hash['Helvetica'] = "Helvetica"
    font_hash['Times New Roman'] = File.join(font_location, 'Times New Roman.ttf')
    font_hash['Verdana'] = File.join(font_location, 'Verdana.ttf')
    font_hash[font_name]
  end
  
  def escape_file_name(name)
    
  end
	
end
