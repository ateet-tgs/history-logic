// auditContextRegistry.js
module.exports = {
  salesorderdet: {
    entityLevel: 2,

    root: {
      table: "salesordermst",
      refField: "refSalesOrderID",
    },

    context: {
      soRevision: {
        query: `
          SELECT revision
          FROM salesordermst
          WHERE id = :rootId
        `,
        map: (row) => row.revision,
      },
    },
  },

  // If more 150 tables live here, but NO CODE duplication
};
