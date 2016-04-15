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

CREATE INDEX product_name ON "Product" USING gin(to_tsvector(english,name));

CREATE INDEX product_price ON "Product" USING btree(price);

CREATE INDEX email ON "Client" USING btree(email);

CREATE INDEX rating ON "Rate" USING btree(rating);

CREATE INDEX wish_product ON "WishList" USING btree(idProduct);

CREATE INDEX person_name ON "Person" USING gin(to_tsvector(name));


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


