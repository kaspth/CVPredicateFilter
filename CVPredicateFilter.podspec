Pod::Spec.new do |s|
  s.name         = "CVPredicateFilter"
  s.version      = "0.1"
  s.summary      = "Flexible filtering of objects on a background thread with NSPredicate."

  s.description  = <<-DESC
                      CVPredicateFilter lets you filter objects with the flexibility af NSPredicate.

                      Enables:
                        - Pushing and popping of filters.
                        - The results of pushing a filter are kept in memory.
                        - Use a template predicate and push a predicate with substitution values.
                        - Use CVCompoundPredicateFilter to combine several filters and let them act as one.
                   DESC

  s.homepage     = "https://github.com/kaspth/CVPredicateFilter"
  s.license      = 'MIT'
  s.author       = { "Kasper Timm Hansen" => "kaspth@gmail.com" }

  s.source       = { :git => "https://github.com/kaspth/CVPredicateFilter.git", :tag => "0.1" }
  s.source_files  = '*.{h,m}'

  s.requires_arc = true
end
