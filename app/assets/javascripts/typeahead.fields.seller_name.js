var seller_names = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/seller_names'
});

$('#seller_name').typeahead(
  {
    hint: false,
    highlight: true,
  },
  {
    name: 'seller_names',
    source: seller_names,
  }
);
