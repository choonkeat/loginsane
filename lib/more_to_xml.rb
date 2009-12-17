module MoreToXml
  def to_xml(options = {})
    options[:indent] ||= 2;
    options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent]);
    options[:builder].value self.to_s
  end
end

String.send(:include, MoreToXml) unless "string".respond_to?(:to_xml)
Symbol.send(:include, MoreToXml) unless :symbol.respond_to?(:to_xml)
# >> puts({:key => [:value1, "value2"]}.to_xml)
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <key type="array">
#     <value>value1</value>
#     <value>value2</value>
#   </key>
# </hash>
