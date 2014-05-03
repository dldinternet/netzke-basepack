{
  init: function(){
    this.callParent(arguments);

    this.searchControls = this.cmp.query('field[attr]');
    this.pagingBar = this.cmp.query('pagingtoolbar')[0];

    Ext.each(this.searchControls, function(control){
      control.on('change', Ext.Function.createBuffered(function(self){
        var query = this.buildQuery();
        this.cmp.getStore().getProxy().extraParams.query = [query];

        if(this.pagingBar) {
          this.pagingBar.moveFirst();
        } else {
          this.cmp.getStore().reload();
        }
      }, this.delay || 500, this));
    }, this);
  },

  buildQuery: function(){
    var query = [];
    Ext.each(this.searchControls, function(f){
      var value = f.getValue();
      if (value) query.push({attr: f.attr, value: value, operator: f.op});
    });
    return query;
  }
}
