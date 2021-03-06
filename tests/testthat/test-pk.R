context("rphenoscape test")

test_that("Test term search", {
  skip_on_cran()
  a <- pk_taxon_detail("Coralliozetus")
  b <- pk_phenotype_detail("shape")
  c <- pk_anatomical_detail("basihyal bone")

  aa <- pk_taxon_detail("coral tt")
  bb <- pk_phenotype_detail("shape tt")
  cc <- pk_anatomical_detail("fin tt")


  g <- pk_gene_detail("socs5")
  gg <- pk_gene_detail("socs5", "Danio rerio")

  expect_is(a, 'data.frame')
  expect_is(b, 'data.frame')
  expect_is(c, 'data.frame')


  expect_equal(aa, FALSE)
  expect_equal(bb, FALSE)
  expect_equal(cc, FALSE)

  expect_is(g, "data.frame")
  expect_is(gg, "data.frame")
})

test_that("Test retriving IRI", {
  skip_on_cran()
  i <- pk_get_iri("Coralliozetus", "vto")
  ii <- pk_get_iri("Coralliozetus TT", "vto")
  iii <- pk_get_iri("Coralliozetus", "pato")

  expect_equal(i, "http://purl.obolibrary.org/obo/VTO_0042955")
  expect_equal(ii, FALSE)
  expect_equal(iii, FALSE)
})


test_that("Test getting classification information", {
  skip_on_cran()
  t <- pk_taxon_class("Fisherichthys")
  tt <- pk_taxon_class("Fisherichthys folmeri")
  ttt <- pk_taxon_class("Fisherichthys TT")

  a <- pk_anatomical_class("fin")
  aa <- pk_anatomical_class("fin FF")

  p <- pk_phenotype_class("shape")
  pp <- pk_phenotype_class("shape SS")

  expect_output(str(t), 'List of 5')
  expect_output(str(tt), 'List of 5')
  expect_equal(ttt, FALSE)

  expect_output(str(a), 'List of 5')
  expect_equal(aa, FALSE)

  expect_output(str(p), 'List of 5')
  expect_equal(pp, FALSE)

})

test_that("Test Descendant/Ancestor", {
  skip_on_cran()
  fl <- pk_is_descendant("Halecostomi", c("Halecostomi", "Icteria", "Sciaenidae"))
  tl <- pk_is_ancestor("Sciaenidae", c("Halecostomi", "Abeomelomys", "Sciaenidae"))

  expect_equal(fl, c(F, F, T))
  expect_equal(tl, c(T, F, F))
})

test_that("Test OnToTrace", {
  skip_on_cran()
  single_nex <- pk_get_ontotrace_xml(taxon = "Ictalurus", entity = "fin")
  multi_nex <- pk_get_ontotrace_xml(taxon = c("Ictalurus", "Ameiurus"), entity = c("fin spine", "pelvic splint"))

  expect_s4_class(single_nex, 'nexml')
  expect_s4_class(multi_nex, 'nexml')

  err1 <- function() pk_get_ontotrace_xml(taxon = "Ictalurus TT", entity = "fin", relation = "other relation")

  f1 <- pk_get_ontotrace_xml(taxon = c("Ictalurus", "Ameiurus XXX"), entity = c("fin", "spine"))
  f2 <- pk_get_ontotrace_xml("Ictalurus TT", "fin")

  expect_error(err1())
  expect_equal(f1, FALSE)
  expect_equal(f2, FALSE)

  single_mat <- pk_get_ontotrace(single_nex)
  multi_mat <- pk_get_ontotrace(multi_nex)

  expect_is(single_mat, 'data.frame')
  expect_is(multi_mat, 'data.frame')

  single_met <- pk_get_ontotrace_meta(single_nex)

  expect_is(single_met, 'list')

})

#
test_that("Test getting study information", {
    skip_on_cran()
    # backwards compatible mode, defaults to including part_of
    slist1 <- pk_get_study_list(taxon = "Siluridae", entity = "fin")
    expect_is(slist1, "data.frame")
    expect_gt(nrow(slist1), 0)

    # only subsumption, no parts or other relationships
    slist2 <- pk_get_study_list(taxon = "Siluridae", entity = "fin", includeRels = FALSE)
    expect_is(slist2, "data.frame")
    expect_gt(nrow(slist2), 0)
    expect_gt(nrow(slist1), nrow(slist2))

    # all supported relationships
    slist3 <- pk_get_study_list(taxon = "Siluridae", entity = "fin", includeRels = TRUE)
    expect_is(slist3, "data.frame")
    expect_gt(nrow(slist3), 0)
    expect_gt(nrow(slist3), nrow(slist2))
    expect_gte(nrow(slist3), nrow(slist1))

    # subsumption and part_of relationships
    slist4 <- pk_get_study_list(taxon = "Siluridae", entity = "fin", includeRels = c("part of"))
    expect_is(slist4, "data.frame")
    expect_gt(nrow(slist4), 0)
    expect_gt(nrow(slist4), nrow(slist2))
    expect_equal(nrow(slist4), nrow(slist1))

    # using prefixes for relationship names works
    slist5 <- pk_get_study_list(taxon = "Siluridae", entity = "fin",
                                includeRels = c("part", "historical", "serial"))
    expect_is(slist5, "data.frame")
    expect_gt(nrow(slist5), 0)
    expect_gt(nrow(slist5), nrow(slist2))
    expect_equal(nrow(slist5), nrow(slist3))

    # filtering by quality works as well
    slist6 <- pk_get_study_list(taxon = "Siluridae", entity = "fin", quality = "size")
    expect_is(slist6, "data.frame")
    expect_gt(nrow(slist6), 0)
    expect_lt(nrow(slist6), nrow(slist4))

    # can also obtain all studies for taxon
    slist7.1 <- pk_get_study_list(taxon = "Siluriformes")
    slist7.2 <- pk_get_study_list(taxon = "Siluriformes", includeRels = FALSE)
    expect_is(slist7.1, "data.frame")
    expect_gt(nrow(slist7.1), 0)
    expect_gt(nrow(slist7.1), 2 * nrow(slist3))
    expect_equal(nrow(slist7.1), nrow(slist7.2))

    # can also obtain all studies for entity
    slist8.1 <- pk_get_study_list(entity = "pelvic fin")
    slist8.2 <- pk_get_study_list(entity = "pelvic fin", includeRels = FALSE)
    slist8.3 <- pk_get_study_list(entity = "pelvic fin", includeRels = c("serial","historical"))
    expect_is(slist8.1, "data.frame")
    expect_gt(nrow(slist8.1), nrow(slist3))
    expect_gt(nrow(slist8.1), nrow(slist7.1))
    expect_gt(nrow(slist8.1), nrow(slist8.2))
    expect_gt(nrow(slist8.3), nrow(slist8.2))

    # can also obtain all studies by leaving off all filters
    slist9 <- pk_get_study_list()
    expect_is(slist9, "data.frame")
    expect_gt(nrow(slist9), 0)
    expect_gt(nrow(slist9), 20 * nrow(slist3))

    s1 <- pk_get_study_xml(slist1[1,"id"])
    expect_is(s1[[1]], 'nexml')

    ss1 <- pk_get_study(s1)
    expect_is(ss1[[1]], 'data.frame')

    sss1 <- pk_get_study_meta(s1)
    expect_is(sss1[[1]], 'list')
    expect_is(sss1[[1]]$id_taxa, 'data.frame')

})



