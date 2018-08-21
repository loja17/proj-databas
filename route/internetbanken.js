/**
 * Route for Internetbanken
 */
"use strict";

const express   	    = require("express");
const router    	    = express.Router();
const bodyParser        = require("body-parser");
const urlencodedParser  = bodyParser.urlencoded({ extended: false });
const internetbanken    = require("../src/internetbanken.js");
const sitename          = "| BankBluffOBåg";

module.exports = router;

router.get("/", (req, res) => {
    let data = {
        title: `Välkommen ${sitename}`
    };

    res.render("internetbanken/index", data);
});

router.get("/admin", async (req, res) => {
    let data = {
        title: `Administration ${sitename}`
    };

    res.render("internetbanken/admin", data);
});

router.get("/admin/kunder", async (req, res) => {
    let data = {
        title: `Kunder ${sitename}`
    };

    data.res = await internetbanken.showTable("showAccountHolder()");

    res.render("internetbanken/admin-kunder", data);
});


router.get("/admin/kunder/ny", async (req, res) => {
    let data = {
        title: `Lägg till kund ${sitename}`
    };

    res.render("internetbanken/admin-kunder-addera", data);
});

router.post("/admin/kunder/ny", urlencodedParser, async (req, res) => {
    let name = req.body.name;
    let born = req.body.born;
    let address = req.body.address;
    let city = req.body.city;
    let pin = req.body.pin;

    await internetbanken.create(`newAccountHolder('${name}', '${born}', 
        '${address}', '${city}', ${pin})`);

    res.redirect(`/internetbanken/admin/kunder`);
});


router.get("/admin/konton", async (req, res) => {
    let totalsumma = await internetbanken.getValue("showSumAccount()");
    let data = {
        title: `Konton ${sitename}`,
        Totalsum: `${totalsumma}`
    };

    data.res = await internetbanken.showTable("showAccounts()");

    res.render("internetbanken/admin-konton", data);
});


router.get("/admin/konton/nytt", async (req, res) => {
    let data = {
        title: `Lägg till konto ${sitename}`
    };

    res.render("internetbanken/admin-konton-addera", data);
});


router.post("/admin/konton/nytt", urlencodedParser, async (req, res) => {
    let accountNumber = req.body.accountNumber;
    let balance = req.body.balance;
    let accountOwner = req.body.accountOwner;

    await internetbanken.create(`newAccount('${accountNumber}', ${balance})`);
    await internetbanken.create(`connectToAccount(${accountOwner}, '${accountNumber}')`);

    res.redirect(`/internetbanken/admin/konton`);
});

router.get("/kund/inloggad/:id", async (req, res) => {
    let id = req.params.id;
    let name = await internetbanken.getValue(`getNameById(${id})`);
    let data = {
        title: `${name} ${sitename}`,
        Namn: name,
        Id: `${id}`
    };

    res.render("internetbanken/kund-inloggad", data);
});


router.get("/admin/konton/nyagare/:id", async (req, res) => {
    let id = req.params.id;
    //let res1;
    let data = {
        title: `Lägg till ägare ${sitename}`,
        Id: `${id}`
    };

    data.res1 = await internetbanken.showTable(`showSingleAccount(${id})`);
    data.res = await internetbanken.showTable(`showAvailableOwners(${id})`);

    res.render("internetbanken/admin-konton-addera-agare", data);
});


router.post("/admin/konton/nyagare/:id/:accountholder_id", urlencodedParser, async (req, res) => {
    let id = req.params.id;
    let accountOwner = req.params.accountholder_id;
    let accountNumber = await internetbanken.getValue(`getAccountNumberById(${id})`);

    await internetbanken.create(`connectToAccount(${accountOwner}, '${accountNumber}')`);

    res.redirect(`/internetbanken/admin/konton`);
});


router.get("/admin/konton/:id", async (req, res) => {
    let id = req.params.id;
    let name = await internetbanken.getValue(`getNameById(${id})`);
    let data = {
        title: `${name} ${sitename}`,
        Namn: name,
        Id: `${id}`
    };

    data.res = await internetbanken.showTable(`showAccountsOfAccountHolder(${id})`);

    res.render("internetbanken/admin-kund-konto", data);
});


router.get("/admin/kalkyl", async (req, res) => {
    let data = {
        title: `Räntekalkyl ${sitename}`
    };

    data.res = await internetbanken.showTable("showAccountsWithInterest()");

    res.render("internetbanken/admin-kalkyl", data);
});


router.get("/admin/logg", async (req, res) => {
    let data = {
        title: `Logg ${sitename}`
    };

    data.res = await internetbanken.showTable("showLog()");

    res.render("internetbanken/admin-logg", data);
});

router.get("/kund", async (req, res) => {
    let data = {
        title: `Kund ${sitename}`
    };

    data.res = await internetbanken.showTable("showAccountHolder()");

    res.render("internetbanken/kund", data);
});


router.get("/kund/inloggad/:id", async (req, res) => {
    let id = req.params.id;
    let name = await internetbanken.getValue(`getNameById(${id})`);
    let data = {
        title: `${name} ${sitename}`,
        Namn: name,
        Id: `${id}`
    };

    res.render("internetbanken/kund-inloggad", data);
});


router.get("/kund/inloggad/konto/:id", async (req, res) => {
    let id = req.params.id;
    let data = {
        title: `Konto ${sitename}`,
        Id: `${id}`
    };

    data.res = await internetbanken.showTable(`showAccountsOfAccountHolder(${id})`);

    res.render("internetbanken/kund-konto", data);
});

router.get("/kund/inloggad/overforing/:id", async (req, res) => {
    let id = req.params.id;
    let data = {
        title: `Konto ${sitename}`,
        Id: `${id}`
    };

    data.res = await internetbanken.showTable(`showAccountsOfAccountHolder(${id})`);

    res.render("internetbanken/kund-overforing", data);
});

router.post("/kund/inloggad/overforing/:id", urlencodedParser, async (req, res) => {
    let id = req.params.id;
    let accountNumber1 = req.body.accountNumber1;
    let accountNumber2 = req.body.accountNumber2;
    let amount = req.body.amount;
    let fromId = await internetbanken.getValue(`getIdByAccountNumber('${accountNumber1}')`);
    let toId = await internetbanken.getValue(`getIdByAccountNumber('${accountNumber2}')`);

    await internetbanken.create(`moveMoney(${fromId}, ${toId}, '${amount}')`);

    res.redirect(`/internetbanken/kund/inloggad/konto/${id}`);
});


router.get("/kund/inloggad/kalkyl/:id", async (req, res) => {
    let id = req.params.id;
    let data = {
        title: `Räntekalkyl ${sitename}`,
        Id: `${id}`
    };

    data.res = await internetbanken.showTable(`showOneAccountInterest(${id})`);

    res.render("internetbanken/kund-kalkyl", data);
});
