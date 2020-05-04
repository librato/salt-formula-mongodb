# MongoDB

MongoDB (from \"humongous\") is an open-source document database, and the leading NoSQL database. Written in C++.

## Installation

After calling this, the following states will want to be ran on the primary mongodb node:

```bash
sudo salt-call state.sls mongodb.cluster
sudo salt-call state.sls mongodb.users
```

## Available states

### `mongodb.server`

Setup MongoDB server

####

#### Sample pillar - Simple single server

``` {.sourceCode .yaml}
mongodb:
  config:
    net:
      bindIp: "0.0.0.0"
      port: 27017
  server:
    version: 3.6
    keyid: 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
    repo_component: multiverse
```

### `mongodb.cluster`

Setup a MongoDB cluster

**When setting up a cluster, the `mongodb.users` state should be applied after applying the `mongodb.cluster` state. If that's not done, users will need to be manually replicated to replica servers.**

#### Sample pillar - Cluster of 3 nodes

``` {.sourceCode .yaml}
mongodb:
  server:
    members:
      - host: 192.168.1.11
        priority: 2
      - host: 192.168.1.12
      - host: 192.168.1.13
    replica_set: default
    shared_key: |
      bEoUQ4QKB8RsJt1cBnO8/2fni3CG+/L2CrGQ+RNJuA5cpIoeehHmWG1ir5mTUx9N
      OLLDvtHT6423395tmGBAJAISv5LXY8PNB6/m1LxsfEDEfjlLwo62z2pMG94ZBPX6
      pGy5YRlii77fi9l5/+d/ULFQSFy6uq5Py0qeFF1IsYsmeSP8GrCExw/9oxWj+Tmv
      qHcmRtm1Edaiokmlwroigbjoiq3kvmbti4+d9jpewoikllfggfteuM4jKBtOjKIt
      MlkkJ0rcIcahTw6x+iWQNDdip5uLS2Xc7i77ZMC4RZmeYVwQ16QtwNdNsTcnoeFC
      FfNIUXCckbZikhyUWlRUZd7NQ6YnQLGKi1Bs0YV0QLmocHFssiB9wnsNynMSgd4i
      zJ/joOlrqmIAmF8BJsa1D+szA4cHc0roWRiCfXvkVjL5fsPNXQpqu0ghPJXigoHJ
      7//HVsmNzX+Tb2hrHdHE+fsdgsagergerfgv43590vsdeZj7kwn6pwrHZpcVLoTi
      ynv7Obl1dHJptRBXqEGBoYcJ2gDNBzuAN9QDpgueVn89s1x/LhHItItBRAwwlsMA
      T++Imel/9qA68kCSzjoj1GZw7CKAAoi9lZSKy5xVzo03K5ZYfaHdPFFG9wqncfH6
      tONxYHv1faQosjPJGQFcwPRqFYzPNzlIOnWYbFUwTJAvXGRcWui/XjpsjAwO7Ba/
      /7hDvlCBgAeor3dPo1d47eCH8ZjCc1pwd8v0fj2q3FvUTEJUsIjH4y3smlzZWR27
      Xx6lINe/i+OhwWHdfg5g354grqeroigger09mkopgepokko4r09tYWWeMjOmrcJH
      tPSe9zc5i+ZbD17npXRTlngaTP5ANKo6PlT2r2tzV06iYaSLyqVPoBA6evHwggcY
      AVw1v99wilvOisIP0n5QgTxpTLA8JHr3Erq7CCDDc+uUbrp0gAf+WATrM5HSNd2M
      YIaOzbYo5Mp71ofF8Xem/ce8GoCCypdWzvrT1DJMDxyt48DF
```

In order to setup a cluster, the `mongodb.cluster` state needs to be run after all cluster instances have booted

To check cluster status, execute following on the cluster primary:

``` {.sourceCode .bash}
# Without Authentication
mongo 127.0.0.1:27017/admin --eval "rs.status()"

# With Authentication
mongo 127.0.0.1:27017/admin -u <admin-user> -p <admin-password> --eval "rs.status()"
```

The shared\_key can be generated through the use of the following open\_ssl command:

``` {.sourceCode .bash}
openssl rand -base64 756
```

### `mongodb.users`

Setup MongoDB authorization and users

**When setting up a cluster, the `mongodb.users` state should be applied after applying the `mongodb.cluster` state. If that's not done, users will need to be manually replicated to replica servers.**

#### Sample pillar - Users/Authorization

``` {.sourceCode .yaml}
mongodb:
  config:
    security:
      authorization: enabled
  server:
    admin:
      name: 'admin'
      password: 'magicunicorn'
    database:
      dbname:
        enabled: true
        encoding: 'utf8'
        users:
        - name: 'username'
          password: 'password'
          roles: ['dbAdmin']
```

### Read more

- <http://docs.mongodb.org/manual/>
- <http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/>
- <http://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/>
- <https://www.linode.com/docs/databases/mongodb/creating-a-mongodb-replication-set-on-ubuntu-12-04-precise>
