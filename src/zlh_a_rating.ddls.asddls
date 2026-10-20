@EndUserText.label: 'Abstract Rating'
define abstract entity zlh_a_rating
{
      @EndUserText.label: 'Rating (1-5 stars)'
      @UI.dataPoint: {
      title  : 'Course Estimation',
      targetValue: 5,
      visualization: #RATING
      }
  key Rating : zlh_rating;

}
