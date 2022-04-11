@enum QueryDetail begin
  LABEL
  SKELETON
  SUMMARY
  FULL
end

const assetGraphVizImg = "http://www.navability.io/wp-content/uploads/2022/03/factor_graph.png"
const assetGeomVizImg = "http://www.navability.io/wp-content/uploads/2022/03/geometric_map.png"

"""
    $TYPEDEF

Helper type for linking to App visualization of a factor graph for user:robot:session.
"""
struct GraphVizApp
  url::String
end

"""
    $TYPEDEF

Helper type for linking to App visualization of geometric map for user:robot:session.
"""
struct MapVizApp
  url::String
end
