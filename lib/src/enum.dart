/// Available land sampling strategies for the globe renderer.
enum MapSamplerType {
  /// Samples land using the packaged texture map.
  imageMapSampler,

  /// Samples land by testing points against packaged GeoJSON polygons.
  geoJsonMapSampler,
}
