/**
 * A module exporting functions to access the ib database.
 */
"use strict";

module.exports = {
    showTable: showTable,
    getValue: getValue,
    create: create,
    showTableAccounts: showTableAccounts
};

const mysql  = require("promise-mysql");
const config = require("../config/db/internetbanken.json");
let db;


/**
 * Main function.
 * @async
 * @returns void
 */
(async function() {
    db = await mysql.createConnection(config);

    process.on("exit", () => {
        db.end();
    });
})();


/**
 * Show entries in the selected table.
 *
 * @async
 * @param {string} procedure for table.
 *
 * @returns {RowDataPacket} Resultset from the query.
 */
async function showTable(proc) {
    let sql = `CALL ${proc};`;
    let res;

    res = await db.query(sql);

    console.info(`SQL: ${sql} got ${res.length} rows.`);

    return res[0];
}



/**
 * Get value.
 *
 * @async
 * @param {string} proc   The procedure to be called.
 *
 * @returns {void}
 */
async function getValue(proc) {
    let sql = `CALL ${proc};`;
    let res;
    let str;

    res = await db.query(sql);
    //console.info(`SQL: ${sql} got ${res.length} rows.`);
    for (const row of res[0]) {
        str = row.n;
    }

    return str;
}


/**
 * Add something to the database
 *
 * @async
 * @param {string} proc   The procedure to be called.
 *
 * @returns {void}
 */
async function create(proc) {
    let sql = `CALL ${proc};`;

    await db.query(sql);
}


/**
 * Show all accounts of accountholder.
 *
 * @async
 * @returns {RowDataPacket} Resultset as table.
 */
async function showTableAccounts(proc) {
    let sql = `CALL ${proc};`;
    let res = await db.query(sql);

    let str;

    str  = "+----+-------------+-----------+-------------------------------";
    str += "--------------------------+\n";
    str += "| Id | Kontonummer | Balans    | Delas med                     ";
    str += "                          |\n";
    str += "|----|-------------|-----------|-------------------------------";
    str += "--------------------------|\n";
    for (const row of res[0]) {
        str += "| ";
        str += row.account_id.toString().padEnd(3);
        str += "| ";
        str += row.accountNumber.padEnd(12);
        str += "| ";
        str += row.balance.toString().padEnd(10);
        str += "| ";
        str += row.shared.padEnd(55);
        str += " |\n";
    }
    str += "+----+-------------+-----------+-------------------------------";
    str += "--------------------------+\n";

    return str;
}
