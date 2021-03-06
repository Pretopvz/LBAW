DROP TABLE IF EXISTS Product CASCADE;
DROP TABLE IF EXISTS Checkout CASCADE;
DROP TABLE IF EXISTS Purchase CASCADE;
DROP TABLE IF EXISTS SupportTicket CASCADE;
DROP TABLE IF EXISTS Client CASCADE;
DROP TABLE IF EXISTS SystemAdministrator CASCADE;
DROP TABLE IF EXISTS Person CASCADE;
DROP TABLE IF EXISTS WishList CASCADE;
DROP TABLE IF EXISTS Tags CASCADE;
DROP TABLE IF EXISTS TagsProducts CASCADE;
DROP TABLE IF EXISTS Rate CASCADE;
DROP TABLE IF EXISTS ShoppingCart CASCADE;

CREATE TABLE Person (
    idPerson SERIAL NOT NULL,
    name text NOT NULL,
    password text NOT NULL CHECK(LENGTH(password) > 6),

    PRIMARY KEY(idPerson)
);

CREATE TABLE SystemAdministrator (
    idPerson integer NOT NULL REFERENCES Person(idPerson),

    PRIMARY KEY(idPerson)
);

CREATE TABLE Client (
    idPerson integer NOT NULL REFERENCES Person(idPerson),
    address text NOT NULL,
    email text UNIQUE NOT NULL,

    PRIMARY KEY(idPerson)
);

CREATE TABLE Product (
    idProduct SERIAL NOT NULL,
    code integer NOT NULL,
    name text NOT NULL,
    price numeric CHECK(price > 0),
    stock integer CHECK(stock >= 0),
    tags integer ARRAY,
    weight numeric CHECK(weight > 0),
    discount numeric CHECK(discount > 0),
    discountEnd Date,
    featured boolean,

    PRIMARY KEY(idProduct)
);

CREATE TABLE Rate (
    idPerson integer NOT NULL REFERENCES Client(idPerson),
    idProduct integer NOT NULL REFERENCES Product(idProduct),
    date date NOT NULL,
    rating numeric CHECK(rating >= 0 AND rating <= 5),
    title text,
    description text,

    CONSTRAINT pk_Rate PRIMARY KEY(idPerson,idProduct)
);

CREATE TABLE ShoppingCart (
    idPerson integer NOT NULL REFERENCES Client(idPerson),
    idProduct integer NOT NULL REFERENCES Product(idProduct),

    CONSTRAINT pk_ShoppingCart PRIMARY KEY(idPerson,idProduct)
);

CREATE TABLE Checkout (
    idCheckout SERIAL NOT NULL,
    date Date NOT NULL,
    idPerson integer NOT NULL,
    CONSTRAINT fk_Client FOREIGN KEY(idPerson) REFERENCES Client(idPerson),


CREATE TABLE Purchase (
    idProduct integer NOT NULL REFERENCES Product(idProduct),
    idCheckout integer NOT NULL,
    price numeric NOT NULL CHECK(price > 0),
    quantity integer CHECK (quantity > 0),

    CONSTRAINT fk_Checkout FOREIGN KEY(idCheckout) REFERENCES Checkout(idCheckout),
    CONSTRAINT pk_Purchase PRIMARY KEY(idProduct)
);

CREATE TABLE SupportTicket (
    idSupportTicket SERIAL NOT NULL,
    createDate date NOT NULL,
    reason text NOT NULL,
    solveDate date CHECK(solveDate > createDate),
    title text NOT NULL,
    idClient integer NOT NULL,
    idAdmin integer NOT NULL,
    idPurchase integer NOT NULL,
    CONSTRAINT fk_Client FOREIGN KEY(idClient) REFERENCES Client(idPerson),
    CONSTRAINT fk_SystemAdmnistrator FOREIGN KEY(idAdmin) REFERENCES SystemAdministrator(idPerson),
    CONSTRAINT fk_Purchase FOREIGN KEY(idPurchase) REFERENCES Purchase(idProduct),

    PRIMARY KEY(idSupportTicket)
);

CREATE TABLE WishList (
    idPerson integer NOT NULL REFERENCES Client(idPerson),
    idProduct integer NOT NULL REFERENCES Product(idProduct),

    CONSTRAINT pk_WishList PRIMARY KEY(idPerson,idProduct)
);

CREATE TABLE Tags (
    idTags SERIAL NOT NULL,
    name text NOT NULL,

    PRIMARY KEY(idTags)
);

CREATE TABLE TagsProducts (
    idTags integer NOT NULL REFERENCES Tags(idTags),
    idProduct integer NOT NULL REFERENCES Product(idProduct),

    CONSTRAINT pk_TagsProducts PRIMARY KEY(idTags,idProduct)
);

-- Indexes

CREATE INDEX idPerson
ON Person USING btree (idPerson);

CREATE INDEX idPerson
ON SystemAdmnistrator USING btree (idPerson);

CREATE INDEX idPerson
ON Client USING btree (idPerson);

CREATE INDEX idProduct
ON Product USING btree (idProduct);

CREATE INDEX idProduct
ON Rate USING btree (idProduct);

CREATE INDEX idPerson
ON Rate USING btree (idPerson);

CREATE INDEX idPerson
ON ShoppingCart USING btree (idPerson);

CREATE INDEX idProduct
ON ShoppingCart USING btree (idProduct);

CREATE INDEX idCheckout
ON Checkout USING btree (idCheckout);

CREATE INDEX idCheckout
ON Purchase USING btree (idCheckout);

CREATE INDEX idProduct
ON Purchase USING btree (idProduct);

CREATE INDEX idSupportTicket
ON SupportTicket USING btree (idSupportTicket);

CREATE INDEX idProduct
ON WishList USING btree (idProduct);

CREATE INDEX idPerson
ON WishList USING btree (idPerson);

CREATE INDEX idTags
ON Tags USING btree (idTags);

CREATE INDEX idProduct
ON TagsProducts USING btree (idProduct);

CREATE INDEX idTags
ON TagsProducts USING btree (idTags);

-- Triggers

CREATE OR REPLACE FUNCTION decStock() RETURNS TRIGGER AS $$
BEGIN
  New.stock = old.stock - quantity;
  RETURN New.stock;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS decStockAfterPurchase ON Product;
CREATE TRIGGER decStockAfterPurchase
BEFORE INSERT ON Purchase
EXECUTE PROCEDURE decStock();


CREATE OR REPLACE FUNCTION deletePurchase() RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM Purchase WHERE OLD.idCheckout =
  Purchase.idCheckout;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS deletePurchase ON Checkout;
CREATE TRIGGER deletePurchase
BEFORE DELETE ON Checkout
EXECUTE PROCEDURE deletePurchase();


CREATE OR REPLACE FUNCTION deletePerson() RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM Client WHERE OLD.idPerson =
  Client.idPerson;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS deletePerson ON Person;
CREATE TRIGGER deletePerson
BEFORE DELETE ON Client
EXECUTE PROCEDURE deletePerson();
