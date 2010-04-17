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
      
      if val.kind_of? Hash and val.length > 5       
        puts "assert_equal %s, %s.%s.length" % [val.length.inspect,obj_name,m]
        
        val.keys.sort{|a,b| a <=> b }.each do |k| 
          puts "assert_equal %s, %s.%s[%s]" % [val[k].inspect,obj_name,m,k.inspect]
        end
#      elsif val.kind_of? Array
#        puts "assert_equal %s, %s.%s.length" % [val.length.inspect,obj_name,m]
#        
#        val.each_index do |i| 
#          pp_assertions  val[i], "%s.%s[%s]" % [obj_name,m,i.inspect]
#        end
      else
        puts "assert_equal %s, %s.%s" % [val.inspect,obj_name,m]
      end
    end    
  end
end