module LibcraigscrapeTestHelpers
  def relative_uri_for(filename)
    'file://%s/%s' % [File.dirname(File.expand_path(__FILE__)), filename]
  end
  
  def pp_assertions(obj, obj_name)
    probable_accessors = (obj.methods-obj.class.superclass.methods)
    
    puts
    probable_accessors.sort.each do |m|
      val = obj.send(m.to_sym)
      
      # There's a good number of transformations worth doing here, I'll just start like this for now:
      if val.kind_of? Time
        # I've decided this is the the easiest way to understand and test a time
        val = val.to_a
        m = "#{m}.to_a"
      end
      
      puts "assert_equal %s, %s.%s" % [val.inspect,obj_name,m]
    end    
  end
end